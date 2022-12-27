package queues;

import promises.Promise;

class SimpleQueue<T> implements IQueue<T> {
    private var items:Array<T> = [];

    public function new() {
    }

    private var _onMessage:T->Promise<Bool>;
    public var onMessage(get, set):T->Promise<Bool>;
    private function get_onMessage():T->Promise<Bool> {
        return _onMessage;
    }
    private function set_onMessage(value:T->Promise<Bool>):T->Promise<Bool> {
        _onMessage = value;
        processQueue();
        return value;
    }

    public function enqueue(item:T) {
        items.push(item);
        processQueue();
    }

    private var _processingItem:Bool = false;
    private function processQueue() {
        if (_onMessage == null || items.length == 0) {
            return;
        }

        if (_processingItem) {
            return;
        }

        _processingItem = true;
        var item = items.shift();
        _onMessage(item).then(success -> {
            _processingItem = false;
            processQueue();
        }, error -> {
            _processingItem = false;
            processQueue();
        });
    }
}